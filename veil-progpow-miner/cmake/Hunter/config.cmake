hunter_config(CURL VERSION ${HUNTER_CURL_VERSION} CMAKE_ARGS HTTP_ONLY=ON CMAKE_USE_OPENSSL=ON CMAKE_USE_LIBSSH2=OFF CURL_CA_PATH=none)
hunter_config(Boost VERSION 1.70.0-p0)

hunter_config(ethash VERSION 1.0.0
    URL https://github.com/VeilCommunity/cpp-ethash/archive/1.0.0.tar.gz
    SHA1 9b2019d1d1af2d554cae4a4fed290a52ea7e55b2
)