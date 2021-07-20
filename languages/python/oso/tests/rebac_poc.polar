


####################################
# Application Relationship Mapping #
####################################

## Relationships that need to be cleared when registering:
    # - repo.org
    # - issue.repo
    # - user.has_role
    # - user.teams

# # User-role mapping to application data
has_role(user: User, role: String, resource: OsoResource) if
    user.has_role(role, resource);

# # Group-role mapping to application data
has_role(group: Team, role: String, resource: OsoResource) if
    group.has_role(role, resource);

has_role(u: User, role: String, resource: OsoResource) if
    team in u.teams and
    team matches Team and   # DO NOT REMOVE: this check is necessary to avoid infinite recursion
    has_role(team, role, resource);


##############
# Org policy #
##############

# Role-based permissions
has_permission(u: User, "add_member", o: Org) if has_role(u, "owner", o);
has_permission(u: User, "delete_repo", o: Org) if has_role(u, "owner", o);
has_permission(u: User, "create_repo", o: Org) if has_role(u, "member", o);
has_permission(u: User, "list_repos", o: Org) if has_role(u, "member", o);

# Org role implications
has_role(u: User, "member", o: Org) if has_role(u, "owner", o);

###############
# Repo policy #
###############

# Role-based permissions
has_permission(u: User, "pull", r: Repo) if has_role(u, "reader", r);
has_permission(u: User, "list_issues", r: Repo) if has_role(u, "reader", r);
has_permission(u: User, "read", i: Issue) if has_role(u, "reader", i.repo);
has_permission(u: User, "push", r: Repo) if has_role(u, "writer", r);
has_permission(u: User, "create_issue", r: Repo) if has_role(u, "writer", r);

# Attribute-based permissions
has_permission(_: User, "view", repo: Repo) if repo.is_public;

# Repo role implications (related)
has_role(u: User, "reader", r: Repo) if has_role(u, "member", r.org);

# Repo role implications (local)
has_role(u: User, "reader", r: Repo) if has_role(u, "writer", r);
has_role(u: User, "writer", r: Repo) if has_role(u, "admin", r);



# TODO:
# - [ ] Make `OsoResource`, `OsoActor`, `OsoGroup` base classes
# - [ ] Divide KB by namespaces
#       - "prototypes" namespace to query for constraints
#       - "data" namespace for mapping to app data? (maybe this is just under relationships)
#       - "relationships" namespace for setting up relationships
# - [ ] Figure out if/how role variants will be specified/defined
# - [ ] Finish validation checks
#       - How to check rule bodies?

# Problems:
# - [ ] role implications don't reference the user, but writing them this way requires including the user