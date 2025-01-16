#!/usr/bin/env python3.9
# -*- coding: utf-8 -*-

# This index.py script will take a filename as input which is assumed to be a file containing YAML data which we will need to parse
# once parsed, we would like to transform this data into an HTML table that lists all of the keys and the values of the YAML data
# here is an example of a typical YAML document that we want this program to be able to process:
#apiVersion: apps/v1
#kind: Deployment
#metadata:
#  name: nginx-deployment
#  labels:
#    app: nginx
#spec:
#  replicas: 3
#  selector:
#    matchLabels:
#      app: nginx
#  template:
#    metadata:
#      labels:
#        app: nginx
#    spec:
#      containers:
#      - name: nginx
#        image: nginx:1.7.9
#        resources:
#          limits:
#            memory: "128Mi"
#            cpu: "500m"
#          requests:
#            memory: "64Mi"
#            cpu: "250m"
#        ports:
#        - containerPort: 80

# We will use the PyYAML library to parse the YAML data and the Jinja2 library to render the HTML table

import sys
from jinja2 import Template
import yaml

def parse_yaml(filename):
    with open(filename, 'r') as file:
        return yaml.safe_load(file)

def generate_html(data):
    template = """
    <html>
    <head>
    <style>
    table {
        font-family: Arial, sans-serif;
        border-collapse: collapse;
        width: 100%;
    }
    th, td {
        border: 1px solid #dddddd;
        text-align: left;
        padding: 8px;
    }
    tr:nth-child(even) {
        background-color: #f2f2f2;
    }
    </style>
    </head>
    <body>
    <h2>YAML to HTML Table</h2>
    <table>
        <tr>
            <th>Key</th>
            <th>Value</th>
        </tr>
        {% for key, value in data.items() %}
        <tr>
            <td>{{ key }}</td>
            <td>{{ value }}</td>
        </tr>
        {% endfor %}
    </table>
    </body>
    </html>
    """
    template = Template(template)
    html = template.render(data=data)
    return html

def main():
    """
    Main function to execute the script.

    Prompts the user to enter a filename, parses the YAML file, generates HTML from the parsed data, and prints the HTML.

    Args:
        None

    Returns:
        None
    """
    filename = input("Enter the filename: ")
    data = parse_yaml(filename)
    html = generate_html(data)
    print(html)

if __name__ == "__main__":
    main()

