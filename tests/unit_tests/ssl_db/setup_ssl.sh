#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

#####
# An example script that creates certificates that can be used for
# testing SSL.  Uses the openssl and keytool commands to:
#
# * Create a CA certificate that can be used to verify the peer's
# certificate.
#
# * Create a server certificate signed by the CA, and a private key
# file. The password for the private key file is 'server-password'
#
# * Create a client certificate signed by the CA, and a private key
# file.  The password for the private key file is 'client-password'.
# This certificate can be used for authentication of a client by the
# server.
#
# openssl is provided by the OpenSSL project.
# keytool is provided by the Java JDK
###

#set -x

OPENSSL=$(type -p openssl)
if [[ ! -x $OPENSSL ]] ; then
    echo >&2 "'openssl' command not available, certificates not generated"
    exit 0
fi

# clean up old stuff
rm -f *.pem

# Create a self-signed certificate for the CA, and a private key to sign certificate requests:
openssl req -x509 -out ca-certificate.pem -days 3650 -nodes -newkey rsa:2048 -keyout ca-private-key.pem -subj "/CN=example.ca.com" -passout pass:ca-password

# Create a certificate for the server.  Use the CA's certificate to sign it:
openssl req -out server-request.csr -days 3650 -newkey rsa:2048  -keyout server-private-key.pem -subj "/CN=*.server.com/OU=812" -passout pass:server-password
openssl x509 -req -in server-request.csr -CA ca-certificate.pem -CAkey ca-private-key.pem -CAcreateserial -out server-certificate.pem -days 3650

# Create a certificate for the client.  Use the CA's certificate to sign it:
openssl req -out client-request.csr -days 3650 -newkey rsa:2048 -keyout client-private-key.pem -subj "/CN=my.client.com/OU=812" -passout pass:client-password
openssl x509 -req -in client-request.csr -CA ca-certificate.pem -CAkey ca-private-key.pem -CAcreateserial -out client-certificate.pem -days 3650

# clean up all the unnecessary stuff
rm -f *.csr *.srl
