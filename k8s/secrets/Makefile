KUBESEAL = kubeseal
KUBECTL = kubectl
KUBECTX = $(KUBECTL) --context $(CONTEXT)
BASE = .secret/$(CONTEXT)
CERT = $(BASE)/public-key-cert.pem
APPLY = $(KUBECTX) apply --force -f

.PHONY: ensure-context
ensure-context:
	@if [ "$(CONTEXT)" == "" ]; then \
		echo "No target context, specify with CONTEXT=<context>"; \
		exit 1; \
	fi

$(BASE): ensure-context
	mkdir -p $(BASE)

.PHONY: template
template: $(BASE)
	-cp -rn .template/* $(BASE)

$(CERT): $(BASE) ensure-context
	$(KUBESEAL) --context $(CONTEXT) --fetch-cert > $@

.PHONY: prepare
prepare: ensure-context $(CERT)

.PHONY: hello-world
hello-world: prepare
	$(KUBECTX) -n default create secret generic $@ \
		--from-env-file=$(BASE)/$@/$@.env \
		--dry-run=client -oyaml | $(KUBESEAL) --cert=$(CERT) -o yaml > ../$@/secret.yml

.PHONY: miniflux
miniflux: prepare
	$(KUBECTX) -n miniflux create secret generic $@ \
		--from-env-file=$(BASE)/$@/$@.env \
		--dry-run=client -oyaml | $(KUBESEAL) --cert=$(CERT) -o yaml > ../$@/secret.yml

.PHONY: freshrss
freshrss: prepare
	$(KUBECTX) -n freshrss create secret generic $@ \
		--from-env-file=$(BASE)/$@/$@.env \
		--dry-run=client -oyaml | $(KUBESEAL) --cert=$(CERT) -o yaml > ../$@/secret.yml

.PHONY: all
all: hello-world miniflux freshrss

