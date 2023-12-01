help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: help

RED=\033[0;31m
YELLOW=\033[0;33m
GREEN=\033[0;32m
NC=\033[0m


_DEFAULT_PHP_VERSION="8.2"
_DEFAULT_PHP_CS_VERSION="3.40.0"
_DEFAULT_PHP_PSALM_VERSION="5.16.0"

BUILD_GET_PHP_VERSION=read -p $$'Use PHP version [${_DEFAULT_PHP_VERSION}]: ' usePhpVersion; \
	usePhpVersion=$${usePhpVersion:-${_DEFAULT_PHP_VERSION}}; \
	echo "PHP version \"$$usePhpVersion\" will be used."

BUILD_GET_PHP_CS_VERSION=read -p $$'Use php-cs-version (${YELLOW}also will be used as an image tag${NC})[${_DEFAULT_PHP_CS_VERSION}]: ' usePhpCsVersion; \
	usePhpCsVersion=$${usePhpCsVersion:-${_DEFAULT_PHP_CS_VERSION}}; \
	echo "CS-Fixer version \"$$usePhpCsVersion\" will be used."

BUILD_GET_PHP_PSALM_VERSION=read -p $$'Use php-psalm-version (${YELLOW}also will be used as an image tag${NC})[${_DEFAULT_PHP_PSALM_VERSION}]: ' usePhpPsalmVersion; \
	usePhpPsalmVersion=$${usePhpPsalmVersion:-${_DEFAULT_PHP_PSALM_VERSION}}; \
	echo "Psalm version \"$$usePhpPsalmVersion\" will be used."

build-and-push-php-cs-fixer: ## Build and push php-cs-fixer image
	@$(BUILD_GET_PHP_VERSION) && $(BUILD_GET_PHP_CS_VERSION) \
		&& docker buildx build \
			-f Dockerfile.cs-fixer \
			--push \
			--platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
			--tag miroff/php-cs-fixer:$${usePhpCsVersion} \
			--build-arg PHP_VERSION=$${usePhpVersion} \
			--build-arg PHP_CS_FIXER_VERSION=$${usePhpCsVersion} \
			.

build-and-push-php-psalm: ## Build and push php-psalm image
	@$(BUILD_GET_PHP_VERSION) && $(BUILD_GET_PHP_PSALM_VERSION) \
		&& docker buildx build \
			-f Dockerfile.psalm \
			--push \
			--platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
			--tag miroff/php-psalm:$${usePhpPsalmVersion} \
			--build-arg PHP_VERSION=$${usePhpVersion} \
			--build-arg PHP_PSALM_VERSION=$${usePhpPsalmVersion} \
			.