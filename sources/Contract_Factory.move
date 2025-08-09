module preethi_addr::ContractFactory {
    use aptos_framework::signer;
    use std::vector;
    use std::string::String;

    /// Struct representing a contract template
    struct ContractTemplate has store, copy, drop {
        name: String,
        template_type: u8,  // 1 = Crowdfunding, 2 = Token, 3 = NFT, etc.
        creator: address,
        deployment_count: u64,
    }

    /// Factory resource to store all contract templates
    struct Factory has key {
        templates: vector<ContractTemplate>,
        total_deployments: u64,
    }

    /// Struct to track deployed contracts for each user
    struct DeployedContracts has key {
        contracts: vector<address>,
        deployment_count: u64,
    }

    /// Initialize the factory (should be called once by the module publisher)
    public fun initialize_factory(admin: &signer) {
        let factory = Factory {
            templates: vector::empty<ContractTemplate>(),
            total_deployments: 0,
        };
        move_to(admin, factory);
    }

    /// Function to create and register a new contract template
    public fun create_template(
        creator: &signer, 
        name: String, 
        template_type: u8
    ) acquires Factory {
        let creator_addr = signer::address_of(creator);
        
        // Create new template
        let template = ContractTemplate {
            name,
            template_type,
            creator: creator_addr,
            deployment_count: 0,
        };

        // Add template to factory
        let factory = borrow_global_mut<Factory>(@preethi_addr);
        vector::push_back(&mut factory.templates, template);
    }

    /// Function to deploy a contract from a template
    public fun deploy_contract(
        deployer: &signer, 
        template_index: u64
    ) acquires Factory, DeployedContracts {
        let deployer_addr = signer::address_of(deployer);
        
        // Update factory statistics
        let factory = borrow_global_mut<Factory>(@preethi_addr);
        factory.total_deployments = factory.total_deployments + 1;
        
        // Update template deployment count
        let template = vector::borrow_mut(&mut factory.templates, template_index);
        template.deployment_count = template.deployment_count + 1;

        // Track deployed contract for the user
        if (!exists<DeployedContracts>(deployer_addr)) {
            let deployed_contracts = DeployedContracts {
                contracts: vector::empty<address>(),
                deployment_count: 0,
            };
            move_to(deployer, deployed_contracts);
        };

        let user_contracts = borrow_global_mut<DeployedContracts>(deployer_addr);
        vector::push_back(&mut user_contracts.contracts, deployer_addr);
        user_contracts.deployment_count = user_contracts.deployment_count + 1;
    }
}