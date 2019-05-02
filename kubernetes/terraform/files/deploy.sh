#!/usr/bin/env bash

kubectl apply -f ../reddit/dev-namespace.yml
kubectl apply -f ../reddit -n dev
