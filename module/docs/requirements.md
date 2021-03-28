## Requirements

### Terraform version
It is recommended to use `terraform` with the following version, or a most updated version
```hcl
required_version = ">= 0.14.0"
```

### Documentation
The documentation is generated using `terraform-docs` library plus some `bash` script which does the following actions:
1. All the documentation is placed in the `/docs` folder.
2. Replace some parts of the documentation, automatically updating it based on `terraform` configuration.
3. The documentation generation will fail whether the `how_to_use_it.md` or the `requirements.md` documentation does not exist on the `doc/` directory.
4. It is automatically generated. 🤖 See [this script](module/docsle/docs/generate_docs.sh)

### Contribution
🚀 Do you wanna contribute, fix or improve anything? ♥️! please follow this [contribution rules](module/docsle/docs/how_to_contribute.md) or contact me to **alex@Ideaup.cl / alex_torres@outlook.com**

### External libraries or tools
- ✅ `terraform-docs` to automatically generate documentation based on `inputs` and `outputs` variables
- ✅ `bash`



