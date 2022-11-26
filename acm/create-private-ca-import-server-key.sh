#!/bin/bash

echo -n "input domain: "
read domain

echo -n "input output directory path: "
read dir

if [ ! -d $dir ]; then
  mkdir $dir
fi

echo -n "input Country Name (2 letter code): "
read C

echo -n "input State or Province Name (full name): "
read ST

echo -n "input Locality Name (eg, city): "
read L

echo -n "input Organization Name (eg, company): "
read O

echo -n "input Common Name (eg, your name or your ca name): "
read CN

echo -n "input SAN textfile path: "
read san

# Root CA
openssl genrsa -out ${dir}/privaterootca.key 2048
openssl req  -new -x509 -key ${dir}/privaterootca.key -sha256 -days 3660 -extensions v3_ca  -out ${dir}/rootca.pem -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN}"
openssl crl2pkcs7 -nocrl -certfile ${dir}/rootca.pem -out ${dir}/rootca.p7b


# Intermediate CA
openssl genrsa -out ${dir}/intermediateca.key 2048
openssl req -new -key ${dir}/intermediateca.key -sha256 -outform PEM -keyform PEM -out ${dir}/intermediateca.csr  -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=${CN}"
touch ${dir}/intermediateca.cnf
echo "[ v3_ca ]" >> ${dir}/intermediateca.cnf
echo "basicConstraints = CA:true, pathlen:0" >> ${dir}/intermediateca.cnf
echo "keyUsage = cRLSign, keyCertSign" >> ${dir}/intermediateca.cnf
echo "nsCertType = sslCA, emailCA" >> ${dir}/intermediateca.cnf
openssl x509 -extfile ${dir}/intermediateca.cnf -req -in ${dir}/intermediateca.csr -sha256 -CA ${dir}/rootca.pem -CAkey ${dir}/privaterootca.key -set_serial 01 -extensions v3_ca  -days 3660 -out ${dir}/intermediateca.pem
openssl crl2pkcs7 -nocrl -certfile ${dir}/intermediateca.pem -out ${dir}/intermediate.p7b

# Server key
openssl genrsa 2048 > ${dir}/server.key
openssl req -new -key ${dir}/server.key -outform PEM -keyform PEM  -sha256 -out ${dir}/server.csr  -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/CN=*.${domain}"
if [ -n "$san" ]; then
  openssl x509 -req -in ${dir}/server.csr -sha256 -CA ${dir}/intermediateca.pem -CAkey ${dir}/intermediateca.key -set_serial 01 -days 366 -out ${dir}/server.pem -extfile ${san}
else
  openssl x509 -req -in ${dir}/server.csr -sha256 -CA ${dir}/intermediateca.pem -CAkey ${dir}/intermediateca.key -set_serial 01 -days 366 -out ${dir}/server.pem
fi

# Import AWS ACM
aws acm import-certificate --certificate fileb://${dir}/server.pem --private-key fileb://${dir}/server.key --certificate-chain fileb://${dir}/intermediateca.pem
