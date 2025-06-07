#!/usr/bin/env python3
"""
Script to execute the 03-create-trigger.sql file in PostgreSQL database
Database: academic_management_database
Schema: academic
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path

def execute_sql_file(host='localhost', port='5432', username='postgres', password=None, 
                    database='academic_management_database', sql_file='03-create-trigger.sql'):
    """
    Execute an SQL file using psql
    
    Args:
        host (str): Database server
        port (str): Connection port
        username (str): Database user
        password (str): Password (optional, can use PGPASSWORD)
        database (str): Database name
        sql_file (str): Path to SQL file
    """
    
    # Check if SQL file exists
    sql_path = Path(sql_file)
    if not sql_path.exists():
        print(f"❌ Error: File {sql_file} does not exist")
        return False
    
    # Build psql command
    cmd = [
        'psql',
        '-h', host,
        '-p', port,
        '-U', username,
        '-d', database,
        '-f', str(sql_path),
        '-v', 'ON_ERROR_STOP=1'  # Stop on error
    ]
    
    # Set environment variables
    env = os.environ.copy()
    if password:
        env['PGPASSWORD'] = password
    
    try:
        print(f"🔄 Executing SQL file: {sql_file}")
        print(f"📍 Database: {database}")
        print(f"🖥️  Server: {host}:{port}")
        print(f"👤 User: {username}")
        print("-" * 50)
        
        # Execute command
        result = subprocess.run(
            cmd,
            env=env,
            capture_output=True,
            text=True,
            check=True
        )
        
        # Show output if any
        if result.stdout:
            print("✅ Output:")
            print(result.stdout)
        
        print("✅ SQL file executed successfully")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Error executing SQL file:")
        print(f"Exit code: {e.returncode}")
        if e.stdout:
            print(f"Standard output: {e.stdout}")
        if e.stderr:
            print(f"Error: {e.stderr}")
        return False
        
    except FileNotFoundError:
        print("❌ Error: 'psql' command not found")
        print("Make sure PostgreSQL is installed and psql is in PATH")
        return False

def main():
    parser = argparse.ArgumentParser(
        description='Execute 03-create-trigger.sql file in PostgreSQL',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Usage examples:
  python execute_trigger.py
  python execute_trigger.py --host localhost --port 5432 --user sga_admin
  python execute_trigger.py --password my_password
  python execute_trigger.py --sql-file ../sql/03-create-trigger.sql
  
Optional environment variables:
  PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE
        """
    )
    
    parser.add_argument('--host', default='localhost',
                       help='Database server (default: localhost)')
    parser.add_argument('--port', default='5432',
                       help='Connection port (default: 5432)')
    parser.add_argument('--user', '--username', default='sga_admin',
                       help='Database user (default: sga_admin)')
    parser.add_argument('--password',
                       help='Password (optional, use PGPASSWORD if not specified)')
    parser.add_argument('--database', default='academic_management_database',
                       help='Database name (default: academic_management_database)')
    parser.add_argument('--sql-file', default='03-create-trigger.sql',
                       help='Path to SQL file (default: 03-create-trigger.sql)')
    
    args = parser.parse_args()
    
    # Use environment variables if available
    host = os.getenv('PGHOST', args.host)
    port = os.getenv('PGPORT', args.port)
    username = os.getenv('PGUSER', args.user)
    password = args.password or os.getenv('PGPASSWORD')
    database = os.getenv('PGDATABASE', args.database)
    
    print("🚀 Starting SQL trigger execution")
    print("=" * 50)
    
    success = execute_sql_file(
        host=host,
        port=port,
        username=username,
        password=password,
        database=database,
        sql_file=args.sql_file
    )
    
    if success:
        print("=" * 50)
        print("🎉 Process completed successfully")
        print("📝 Trigger 'trigger_audit_student' has been created")
        print("📊 Function 'audit_student_changes()' is ready")
        sys.exit(0)
    else:
        print("=" * 50)
        print("💥 Process failed")
        sys.exit(1)

if __name__ == '__main__':
    main()