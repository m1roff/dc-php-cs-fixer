help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: help

RED=\033[0;31m
YELLOW=\033[0;33m
GREEN=\033[0;32m
NC=\033[0m


_DEFAULT_PHP_VERSION="8.3"
_DEFAULT_PHP_CS_VERSION="3.41.1"
_DEFAULT_PHP_PSALM_VERSION="5.18.0"

PUBLISH_TAGS=latest

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

BASE_IMAGE_K8S="miroff/ci-kubectl"
build-and-push-ci-kubectl: ## Build and push kubeclt image
	@echo "Введите дополнительные теги (разделенные пробелами) Уже установленные: ${PUBLISH_TAGS}:"; \
    	read extra_tags; \
    	PUBLISH_TAGS="${PUBLISH_TAGS} $${extra_tags}"; \
    	echo "Теги для публикации:"; \
    	for tag in $$PUBLISH_TAGS; do \
    	    echo "  -> "$$tag ; \
    	done; \
    	read -p $$'${RED}Продолжить?! ${NC}[${YELLOW}если да то "Y"${NC}]: ' continueDump; \
    		if [ "$${continueDump}" != "Y" ]; then echo "${YELLOW}Nothing will be done. Exiting.${NC}" && exit; fi; \
    		built_tags=$$(for tag_name in $$PUBLISH_TAGS; do printf "%s " "--tag $(BASE_IMAGE_K8S):$$tag_name"; done); \
    		docker buildx build \
    			--cache-from $(BASE_IMAGE_K8S):$(PULL_TAG) \
    			--push \
				--platform linux/arm64/v8,linux/amd64 \
    			$${built_tags} \
    			-f Dockerfile.ci-kubectl . ;

BASE_IMAGE_MYSQL_CLIENT="miroff/mysql-client"
build-and-push-mysql-client: ## Build and push MySQL Client
	@echo "Введите дополнительные теги (разделенные пробелами) Уже установленные: ${PUBLISH_TAGS}:"; \
    	read extra_tags; \
    	PUBLISH_TAGS="${PUBLISH_TAGS} $${extra_tags}"; \
    	echo "Теги для публикации:"; \
    	for tag in $$PUBLISH_TAGS; do \
    	    echo "  -> "$$tag ; \
    	done; \
    	read -p $$'${RED}Продолжить?! ${NC}[${YELLOW}если да то "Y"${NC}]: ' continueDump; \
    		if [ "$${continueDump}" != "Y" ]; then echo "${YELLOW}Nothing will be done. Exiting.${NC}" && exit; fi; \
    		built_tags=$$(for tag_name in $$PUBLISH_TAGS; do printf "%s " "--tag $(BASE_IMAGE_MYSQL_CLIENT):$$tag_name"; done); \
    		docker buildx build \
    			--cache-from $(BASE_IMAGE_MYSQL_CLIENT):$(PULL_TAG) \
    			--push \
				--platform linux/arm64/v8,linux/amd64 \
    			$${built_tags} \
    			-f Dockerfile.mysql-client . ;