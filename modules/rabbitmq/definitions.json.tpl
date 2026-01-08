{
  "bindings": [],
  "exchanges": [],
  "global_parameters": [
    {
      "name": "cluster_name",
      "value": "rabbit@${environment}"
    }
  ],
  "parameters": [],
  "permissions": [
     %{ for user, vhosts in permissions ~}
      %{ for vhost, perms in vhosts ~}
        {
          "read": "${perms[0]}",
          "write": "${perms[1]}",
          "configure": "${perms[2]}",
          "user": "${user}",
          "vhost": "${vhost}"
        } %{if ((index(keys(permissions), user) == length(keys(permissions)) -1)  && (index(keys(vhosts), vhost) == length(keys(vhosts)) -1 ) ) }%{ else },%{ endif }
      %{ endfor ~}
    %{ endfor ~} 
  ],
  "policies": [],
  "queues": [],
  "rabbit_version": "3.8.21",
  "rabbitmq_version": "3.8.21",
  "topic_permissions": [],
  "users": [
    %{ for user, pass in users ~}
      {
      "hashing_algorithm": "rabbit_password_hashing_sha256",
      "limits": {},
      "name": "${user}",
      "password": "${pass}",
      "tags": %{if (user == admin_user) ~}"administrator"%{ else ~}""%{ endif ~}
    } %{if (index(keys(users), user) < length(keys(users)) -1 )~},%{ endif ~}
    %{ endfor ~}
  ],
  "vhosts": [
    %{ for vhost in vhosts ~}
    {
      "limits": [],
      "metadata": {
        "description": "undefined",
        "tags": []
      },
      "name": "${vhost}"
    } %{if (index(vhosts, vhost) < length(vhosts) -1 )},%{ endif }
    %{ endfor ~}
  ]
}