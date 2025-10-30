#!/bin/sh
set -e

echo "🚀 Bootstrapping Garage..."
mkdir -p /var/lib/garage/meta /var/lib/garage/data /data /credentials

garage server &
SERVER_PID=$!

echo "⏳ Waiting for Garage to be ready..."
sleep 5

NODE_ID=$(garage node id 2>&1 | grep -o '[0-9a-f]\{16\}' | head -n1)
echo "🧩 Node ID: $NODE_ID"

# Appliquer le layout si nécessaire
if garage status 2>&1 | grep -q "NO ROLE ASSIGNED"; then
    echo "🧩 Configuring layout..."
    garage layout assign "$NODE_ID" -z dc1 -c 1G -t node1
    garage layout apply --version 1
    sleep 5
    echo "✅ Layout configured"
fi

# Créer la clé S3 et sauvegarder les credentials
if [ ! -f /credentials/.ready ]; then
    echo "🔑 Creating S3 credentials..."
    sleep 3
    
    # Capturer la sortie de la création de clé
    KEY_OUTPUT=$(garage key create bigdata-admin 2>&1)
    echo "$KEY_OUTPUT" | tee /data/s3-key.txt
    
    # Extraire ACCESS_KEY et SECRET_KEY
    ACCESS_KEY=$(echo "$KEY_OUTPUT" | grep -i "key id" | awk '{print $NF}' || echo "$KEY_OUTPUT" | grep "^GK" | head -n1)
    SECRET_KEY=$(echo "$KEY_OUTPUT" | grep -i "secret" | awk '{print $NF}' || echo "$KEY_OUTPUT" | grep -v "^GK" | tail -n1)
    
    # Sauvegarder dans le volume partagé
    echo "$ACCESS_KEY" > /credentials/access_key
    echo "$SECRET_KEY" > /credentials/secret_key
    
    # Donner les permissions
    garage key allow bigdata-admin --create-bucket
    
    # Marquer comme prêt
    touch /credentials/.ready
    
    echo "✅ Credentials saved to /credentials/"
    echo "   ACCESS_KEY: $ACCESS_KEY"
fi

# Créer un bucket par défaut
if ! garage bucket list 2>&1 | grep -q "bigdata"; then
    echo "🪣 Creating bigdata bucket..."
    garage bucket create bigdata
    garage bucket allow --read --write bigdata --key bigdata-admin
    echo "✅ bigdata bucket created"
fi

echo "🎉 Garage is fully initialized and ready!"
garage status

wait $SERVER_PID