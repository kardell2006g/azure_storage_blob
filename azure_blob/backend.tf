terraform {
  cloud {
    organization = "gekk0"

    workspaces {
      name = "azure_blob"
    }
  }
}