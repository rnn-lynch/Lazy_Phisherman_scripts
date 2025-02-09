#!/usr/bin/env python3
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Microsoft email generator
# @raycast.mode silent
# @raycast.packageName 

# Optional parameters:
# @raycast.icon 🔍

# Documentation:
# @raycast.author Rónán Lynch (ZeroCraic)
# @raycast.description Uses the clipboard.


import random
import subprocess

# Generate a random email address
def generate_random_email_address():
    common_first_names = [
        'James', 'John', 'Robert', 'Michael', 'William',
        'David', 'Joseph', 'Charles', 'Thomas', 'Daniel',
        'Jesse', 'Chris', 'Derek', 'Tony', 'Carl'

    ]
    common_last_names = [
        'Smith', 'Johnson', 'Williams', 'Brown', 'Jones',
        'Long', 'Patterson', 'Hughes', 'Washington', 'Butler',
        'Reynolds', 'Fisher', 'Ellis', 'Harrison', 'Gibson'
    ]
    company_domains = ['microsoft.com']

    first_name = random.choice(common_first_names)
    last_name = random.choice(common_last_names)
    random_number = random.randint(1, 99)
    domain = random.choice(company_domains)

    return f"{first_name}.{last_name}{random_number}@{domain}"

# Main script logic
email = generate_random_email_address()

# Copy the email to clipboard
subprocess.run("pbcopy", universal_newlines=True, input=email)

# Output to confirm the email is copied
print(f"Random email '{email}' has been copied to your clipboard.")