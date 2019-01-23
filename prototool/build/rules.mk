GO                     := go
GRPC_TOOLS_RUBY_PROTOC := grpc_tools_ruby_protoc
PROTOTOOL              := prototool

RB_GEN_FILES = \
	$(MODULES:%=build/ruby/lib/%_pb.rb) \
	$(MODULES:%=build/ruby/lib/%_services_pb.rb) \
	build/ruby/proto.gemspec

GO_GEN_FILES = \
	$(MODULES:%=build/go/%.pb.go)

ifndef VERSION
VERSION = $(shell cat VERSION)
endif

define RB_GEMSPEC
lib = File.expand_path('../lib', __FILE__)
$$LOAD_PATH.unshift(lib) unless $$LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
	spec.name = 'jobteaser-proto'
	spec.version = '$(VERSION)'
	spec.authors = ['Jobteaser']
	spec.email = ['dev@jobteaser.com']

	spec.summary = 'proto files for ruby'
	spec.description = 'This gem contains generated protocol buffer files for ruby'

	spec.require_paths = ['lib']
end
endef

export RB_GEMSPEC

# Force this one because it depends on variable VERSION
build/ruby/proto.gemspec: .FORCE
	@mkdir -p $(@D)
	@echo "$$RB_GEMSPEC" > $@

build/ruby/lib/%_pb.rb build/go/%.pb.go: %.proto
	@mkdir -p $(@D)
	@$(PROTOTOOL) generate $<

build/ruby/lib/%_services_pb.rb: %.proto
	@mkdir -p $(@D)
	@$(GRPC_TOOLS_RUBY_PROTOC) --grpc_out=build/ruby/lib/ $<

.PHONY: generate
generate: \
	$(RB_GEN_FILES) \
	$(GO_GEN_FILES)

.PHONY: lint
lint:
	@$(PROTOTOOL) lint

.PHONY: clean
clean:
	rm -rf build

.DEFAULT_GOAL := all
.PHONY: all
all: lint generate

.FORCE: