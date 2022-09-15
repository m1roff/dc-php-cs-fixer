help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: help

RED=\033[0;31m
YELLOW=\033[0;33m
GREEN=\033[0;32m
NC=\033[0m


_DEFAULT_PHP_VERSION="8.1"
_DEFAULT_PHP_CS_VERSION="3.11.0"

BUILD_GET_PHP_VERSION=read -p $$'Use PHP version [${_DEFAULT_PHP_VERSION}]: ' usePhpVersion; \
	usePhpVersion=$${usePhpVersion:-${_DEFAULT_PHP_VERSION}}; \
	echo "PHP version \"$$usePhpVersion\" will be used."

BUILD_GET_PHP_CS_VERSION=read -p $$'Use php-cs-version (${YELLOW}also will be used as an image tag${NC})[${_DEFAULT_PHP_CS_VERSION}]: ' usePhpCsVersion; \
	usePhpCsVersion=$${usePhpCsVersion:-${_DEFAULT_PHP_CS_VERSION}}; \
	echo "PHP version \"$$usePhpCsVersion\" will be used."

build:
	@$(BUILD_GET_PHP_VERSION) && $(BUILD_GET_PHP_CS_VERSION) \
		&& docker buildx build --push --platform linux/arm/v7,linux/arm64/v8,linux/amd64 --tag miroff/php-cs-fixer:$${usePhpCsVersion} --build-arg PHP_VERSION=$${usePhpVersion} --build-arg PHP_CS_FIXER_VERSION=$${usePhpCsVersion} .