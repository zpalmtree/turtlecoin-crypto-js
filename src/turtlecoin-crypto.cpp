// Copyright (c) 2018, The TurtleCoin Developers
//
// Please see the included LICENSE file for more information.

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include "crypto.h"
#include "hash.h"
#include "StringTools.h"
#include <emscripten/bind.h>

using namespace emscripten;
using BinaryArray = std::vector<uint8_t>;

struct Keys
{
  std::string PublicKey;
  std::string SecretKey;
};

Keys generateKeys() {
  Crypto::PublicKey pub;
  Crypto::SecretKey sec;

  Crypto::generate_keys(pub, sec);

  Keys keys;
  keys.PublicKey = Common::toHex(&pub, sizeof(pub));
  keys.SecretKey = Common::toHex(&sec, sizeof(sec));

  return keys;
}

std::vector<std::string> generateRingSignatures(std::string prefixHash, std::string keyImage, std::vector<std::string> publicKeys, std::string transactionSecretKey, unsigned int realOutput)
{
  std::vector<std::string> sigs;
  
  Crypto::Hash c_prefixHash = Crypto::Hash();
  Common::podFromHex(prefixHash, c_prefixHash);

  Crypto::KeyImage c_keyImage = Crypto::KeyImage();
  Common::podFromHex(keyImage, c_keyImage);
  
  std::vector<Crypto::PublicKey> c_publicKeys;
  for (size_t i = 0; i < publicKeys.size(); i++)
  {
    Crypto::PublicKey l_publicKey = Crypto::PublicKey();
    Common::podFromHex(publicKeys[i], l_publicKey);
    c_publicKeys.push_back(l_publicKey);
  }
  
  Crypto::SecretKey c_transactionSecretKey = Crypto::SecretKey();
  Common::podFromHex(transactionSecretKey, c_transactionSecretKey);
  
  uint64_t c_realOutput = (uint64_t)realOutput;
  
  const auto [success, c_sigs] = Crypto::crypto_ops::generateRingSignatures(c_prefixHash, c_keyImage, c_publicKeys, c_transactionSecretKey, c_realOutput);
  
  if (success)
  {
    for (const auto sig : c_sigs)
    {
        sigs.push_back(Common::toHex(&sig, sizeof(sig)));
    }
  }
  
  return sigs;
}

std::string generateKeyImage(std::string publicKey, std::string privateKey)
{
  std::string keyImage;
  
  Crypto::PublicKey c_publicKey = Crypto::PublicKey();
  Common::podFromHex(publicKey, c_publicKey);
  
  Crypto::SecretKey c_privateKey = Crypto::SecretKey();
  Common::podFromHex(privateKey, c_privateKey);
  
  Crypto::KeyImage c_keyImage = Crypto::KeyImage();
  
  Crypto::generate_key_image(c_publicKey, c_privateKey, c_keyImage);
  
  keyImage = Common::podToHex(c_keyImage);
  
  return keyImage;
}

std::string cn_fast_hash(std::string data)
{
  std::string hash;
  
  const BinaryArray& rawData = Common::fromHex(data);
  
  Crypto::Hash c_hash = Crypto::Hash();
  Crypto::cn_fast_hash(rawData.data(), rawData.size(), c_hash);
  
  hash = Common::podToHex(c_hash);
  
  return hash;
}

EMSCRIPTEN_BINDINGS(signatures)
{
  function("generateRingSignatures", &generateRingSignatures);
  function("generate_keys", &generateKeys);
  function("generate_key_image", &generateKeyImage);
  function("cn_fast_hash", &cn_fast_hash);
  
  register_vector<std::string>("VectorString");

  value_object<Keys>("Keys")
    .field("SecretKey", &Keys::SecretKey)
    .field("PublicKey", &Keys::PublicKey);
}