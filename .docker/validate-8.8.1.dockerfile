FROM    phadej/ghc:8.8.1-bionic

# Install cabal-plan
RUN     mkdir -p /root/.cabal/bin && \
        curl -L https://github.com/haskell-hvr/cabal-plan/releases/download/v0.6.2.0/cabal-plan-0.6.2.0-x86_64-linux.xz > cabal-plan.xz && \
        echo "de73600b1836d3f55e32d80385acc055fd97f60eaa0ab68a755302685f5d81bc  cabal-plan.xz" | sha256sum -c - && \
        xz -d < cabal-plan.xz > /root/.cabal/bin/cabal-plan && \
        rm -f cabal-plan.xz && \
        chmod a+x /root/.cabal/bin/cabal-plan

# install cabal-env
RUN     curl -sL https://github.com/phadej/cabal-extras/releases/download/preview-20191225/cabal-env-snapshot-20191225-x86_64-linux.xz > cabal-env.xz && \
        echo "1b567d529c5f627fd8c956e57ae8f0d9f11ee66d6db34b7fb0cb1c370b4edf01  cabal-env.xz" | sha256sum -c - && \
        xz -d < cabal-env.xz > $HOME/.cabal/bin/cabal-env && \
        rm -f cabal-env.xz && \
        chmod a+x $HOME/.cabal/bin/cabal-env

# Update index
RUN     cabal v2-update

# We install happy, so it's in the store; we (hopefully) don't use it directly.
RUN     cabal v2-install happy --constraint 'happy ^>=1.19.12'
RUN     cabal v2-install doctest --constraint 'doctest ^>= 0.16.2'

# Install some other dependencies
# Remove $HOME/.ghc so there aren't any environments
RUN     cabal v2-install -w ghc-8.8.1 --lib \
          aeson \
          async \
          base-compat \
          base16-bytestring \
          base64-bytestring \
          cryptohash-sha256 \
          Diff \
          echo \
          ed25519 \
          edit-distance \
          haskell-lexer \
          HTTP \
          network \
          optparse-applicative \
          pretty-show \
          regex-compat-tdfa \
          regex-tdfa \
          resolv \
          statistics \
          tar \
          tasty \
          tasty-golden \
          tasty-hunit \
          tasty-quickcheck \
          tree-diff \
          zlib \
        && rm -rf $HOME/.ghc

# Validate
WORKDIR /build
COPY    . /build
RUN     sh ./validate.sh -w ghc-8.8.1 -v --doctest --solver-benchmarks --complete-hackage-tests
