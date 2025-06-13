#!/usr/bin/env python3
import os
import sys
import argparse
import psycopg2
import time
import logging
from psycopg2 import errors
from tqdm import tqdm

# Configuración del logger
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger('academic_pipeline')

class SQLPipeline:
    def __init__(self):
        self.args = self.parse_arguments()
        self.conn = None
        self.standard_sql_files = [
            '01-period.sql',
            '02-room.sql',
            '03-student.sql',
            '04-professor.sql',
            '05-course.sql',
            '06-course_assignment.sql',
            '07-evaluation.sql',
            '08-schedule.sql',
            '09-enrollment.sql',
            '10-grade_evaluation.sql',
            '11-prerequisite.sql'
        ]
        self.delay_between_files = self.args.delay

    def parse_arguments(self):
        parser = argparse.ArgumentParser(description='Academic PostgreSQL Pipeline')
        parser.add_argument('--host', default='localhost', help='PostgreSQL host')
        parser.add_argument('--port', default=5432, type=int, help='PostgreSQL port')
        parser.add_argument('--user', required=True, help='Database user')
        parser.add_argument('--password', required=True, help='Database password')
        parser.add_argument('--db-name', default='academic_management_database', help='Database name')
        parser.add_argument('--schema-name', default='academic', help='Schema name')
        parser.add_argument('--sql-dir', default='.', help='Directory with SQL files')
        parser.add_argument('--max-retries', type=int, default=3, help='Max retries')
        parser.add_argument('--delay', type=float, default=1.0, help='Delay between files')
        parser.add_argument('--debug', action='store_true', help='Enable debug mode')
        parser.add_argument('--continue-on-error', action='store_true', help='Continue pipeline on errors')
        return parser.parse_args()

    def connect_postgres(self):
        for attempt in range(self.args.max_retries):
            try:
                conn = psycopg2.connect(
                    host=self.args.host,
                    port=self.args.port,
                    user=self.args.user,
                    password=self.args.password,
                    dbname=self.args.db_name
                )
                logger.info("✅ Connected to PostgreSQL")
                return conn
            except (psycopg2.OperationalError, psycopg2.InterfaceError) as e:
                logger.warning(f"Connection attempt {attempt + 1} failed: {e}")
                time.sleep(2 ** attempt)
        logger.error("❌ Connection failed after maximum retries")
        return None

    def validate_sql_file(self, file_path):
        if not os.path.exists(file_path):
            logger.error(f"File does not exist: {file_path}")
            return False
        if not os.access(file_path, os.R_OK):
            logger.error(f"File is not readable: {file_path}")
            return False
        if os.path.getsize(file_path) == 0:
            logger.error(f"File is empty: {file_path}")
            return False
        return True

    def parse_sql_statements(self, sql_content):
        """Improved SQL statement parsing that handles comments and edge cases"""
        import re
        
        # Remove SQL comments (-- style)
        lines = sql_content.split('\n')
        cleaned_lines = []
        
        for line in lines:
            # Remove inline comments but preserve strings
            if '--' in line:
                # Simple approach: if -- is not inside quotes, remove everything after it
                in_quotes = False
                quote_char = None
                for i, char in enumerate(line):
                    if char in ('"', "'") and (i == 0 or line[i-1] != '\\'):
                        if not in_quotes:
                            in_quotes = True
                            quote_char = char
                        elif char == quote_char:
                            in_quotes = False
                            quote_char = None
                    elif char == '-' and i < len(line) - 1 and line[i+1] == '-' and not in_quotes:
                        line = line[:i].rstrip()
                        break
            cleaned_lines.append(line)
        
        cleaned_content = '\n'.join(cleaned_lines)
        
        # Split by semicolon and filter out empty statements
        statements = []
        raw_statements = cleaned_content.split(';')
        
        for stmt in raw_statements:
            cleaned_stmt = stmt.strip()
            if cleaned_stmt and not cleaned_stmt.isspace():
                statements.append(cleaned_stmt)
        
        return statements

    def debug_sql_content(self, file_path, sql_commands):
        """Debug SQL content for common issues"""
        # Use improved parsing
        statements = self.parse_sql_statements(sql_commands)
        
        # Only show debug info if there are issues
        issues = []
        
        # Check for unmatched quotes
        single_quotes = sql_commands.count("'")
        double_quotes = sql_commands.count('"')
        if single_quotes % 2 != 0:
            issues.append("Unmatched single quotes detected")
        if double_quotes % 2 != 0:
            issues.append("Unmatched double quotes detected")
        
        # Only show debug info if there are problems
        if issues:
            logger.warning(f"🔍 Issues found in {file_path}: {', '.join(issues)}")
        
        return statements

    def execute_sql_file(self, file_path):
        if not self.validate_sql_file(file_path):
            return False

        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                sql_commands = f.read()
        except Exception as e:
            logger.error(f"Failed to read {file_path}: {e}")
            return False

        # Debug mode: analyze SQL content
        if self.args.debug:
            statements = self.debug_sql_content(file_path, sql_commands)
        else:
            statements = self.parse_sql_statements(sql_commands)

        try:
            with self.conn.cursor() as cur:
                for i, statement in enumerate(tqdm(statements, desc=f"Executing {os.path.basename(file_path)}", leave=False), 1):
                    try:
                        cur.execute(statement)
                    except errors.Error as e:
                        error_msg = f"SQL Error in statement {i}: {e.pgerror if hasattr(e, 'pgerror') else str(e)}"
                        logger.error(error_msg)
                        
                        if self.args.debug:
                            logger.error(f"Problematic statement: {statement}")
                        
                        self.conn.rollback()
                        
                        if not self.args.continue_on_error:
                            return False
                        else:
                            logger.warning("Continuing despite error due to --continue-on-error flag")
                            
            self.conn.commit()
            logger.info(f"✅ {file_path} executed successfully")
            return True
            
        except Exception as e:
            logger.error(f"Execution failed for {file_path}: {e}")
            self.conn.rollback()
            return False

    def check_table_dependencies(self):
        """Check if required tables exist before running problematic files"""
        try:
            with self.conn.cursor() as cur:
                # Check if required tables exist for course_assignment
                cur.execute("""
                    SELECT table_name 
                    FROM information_schema.tables 
                    WHERE table_schema = %s 
                    AND table_name IN ('course', 'professor', 'period')
                """, (self.args.schema_name,))
                
                existing_tables = [row[0] for row in cur.fetchall()]
                
                required_tables = ['course', 'professor', 'period']
                missing_tables = [t for t in required_tables if t not in existing_tables]
                
                if missing_tables:
                    logger.warning(f"Missing required tables: {missing_tables}")
                    return False
                    
                return True
                
        except Exception as e:
            logger.error(f"Error checking table dependencies: {e}")
            return False

    def run(self):
        logger.info("🚀 Starting Academic SQL Data Pipeline")
        self.conn = self.connect_postgres()
        if not self.conn:
            sys.exit(1)

        try:
            success = 0
            failed_files = []
            
            for sql_file in self.standard_sql_files:
                full_path = os.path.join(self.args.sql_dir, sql_file)
                
                # Special handling for course_assignment.sql
                if sql_file == '06-course_assignment.sql':
                    if not self.check_table_dependencies():
                        logger.error("Dependencies not met for course_assignment.sql")
                        if not self.args.continue_on_error:
                            break
                
                if self.execute_sql_file(full_path):
                    success += 1
                else:
                    logger.error(f"❌ Failed at {sql_file}")
                    failed_files.append(sql_file)
                    if not self.args.continue_on_error:
                        break
                        
                time.sleep(self.delay_between_files)
                
            logger.info(f"🎓 Pipeline completed: {success}/{len(self.standard_sql_files)} files loaded.")
            if failed_files:
                logger.error(f"Failed files: {', '.join(failed_files)}")
                
        finally:
            if self.conn:
                self.conn.close()
                logger.info("🔒 Database connection closed.")

if __name__ == "__main__":
    pipeline = SQLPipeline()
    pipeline.run()