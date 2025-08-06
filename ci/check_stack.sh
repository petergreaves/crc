#!/bin/bash

# Function to check if CloudFormation stack exists
# Usage: check_stack_exists <stack-name>
# Returns: 1 if stack exists, 0 if it doesn't

check_stack_exists() {
    local stack_name="$1"

    # Check if stack name is provided
    if [ -z "$stack_name" ]; then
        echo "Error: Stack name is required" >&2
        echo "Usage: check_stack_exists <stack-name>" >&2
        return 2
    fi

    # Check if stack exists using AWS CLI
    aws cloudformation describe-stacks --stack-name "$stack_name" &>/dev/null

    if [ $? -eq 0 ]; then
        # Stack exists
        return 1
    else
        # Stack doesn't exist
        return 0
    fi
}

# Main execution if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Check if argument is provided
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <stack-name>"
        echo "Returns: 1 if stack exists, 0 if it doesn't"
        exit 2
    fi

    stack_name="$1"

    # Call the function
    check_stack_exists "$stack_name"
    result=$?

    # Print result and exit with the return code
    if [ $result -eq 1 ]; then
        echo "Stack '$stack_name' exists"
        exit 1
    elif [ $result -eq 0 ]; then
        echo "Stack '$stack_name' does not exist"
        exit 0
    else
        # Error case
        exit 2
    fi
fi