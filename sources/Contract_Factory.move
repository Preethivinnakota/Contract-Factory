module preethi_addr::ContractFactory {
    use aptos_framework::signer;
    use std::vector;
    use std::string::String;

    struct ContractTemplate has store, copy, drop {
        name: String,
        template_type: u8,  
        creator: address,
        deployment_count: u64,
    }

    struct Factory has key {
        templates: vector<ContractTemplate>,
        total_deployments: u64,
    }

    struct DeployedContracts has key {
        contracts: vector<address>,
        deployment_count: u64,
    }

    public fun initialize_factory(admin: &signer) {
        let factory = Factory {
            templates: vector::empty<ContractTemplate>(),
            total_deployments: 0,
        };
        move_to(admin, factory);
    }

    public fun create_template(
        creator: &signer, 
        name: String, 
        template_type: u8
    ) acquires Factory {
        let creator_addr = signer::address_of(creator);
        
        let template = ContractTemplate {
            name,
            template_type,
            creator: creator_addr,
            deployment_count: 0,
        };

        let factory = borrow_global_mut<Factory>(@preethi_addr);
        vector::push_back(&mut factory.templates, template);
    }

    public fun deploy_contract(
        deployer: &signer, 
        template_index: u64
    ) acquires Factory, DeployedContracts {
        let deployer_addr = signer::address_of(deployer);
        
        let factory = borrow_global_mut<Factory>(@preethi_addr);
        factory.total_deployments = factory.total_deployments + 1;
        
        let template = vector::borrow_mut(&mut factory.templates, template_index);
        template.deployment_count = template.deployment_count + 1;

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
