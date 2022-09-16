Title: Proxmox + salt-cloud = &#60;kinda3
Date: 2017-06-17 03:53
Author: roy.
Tags: salt-cloud, proxmox, cloud, virtualization, saltstack
Slug: proxmox-salt-cloud-kinda3

<!--kg-card-begin: markdown-->

So, I've been working on getting salt-cloud playing nicely with Proxmox. The biggest issue I've seen so far is within salt-cloud's proxmox driver is more of a limitation within proxmox itself.

</p>

Unless you statically assign you IP address, you're not going to see your IP address in the GUI or in the standard salt-cloud query to your hypervisor. The proxmox driver also allows your to query DNS for  

the IP address of your machine.

</p>

Neither of those really work for me at home, since I like to have my VMs get an address from DHCP, then convert that to a static reservation when I'm sure that VM will stick around.

</p>

My prefered solution would be to pull the IP address straight from the hypervisor, which would make my life so much easier. That's doable when you're using the VMWare/ESXi driver when the agent is  

installed, I figure that there should be a way of handling that within Proxmox.

</p>

Enter the [QEMU Guest Agent](https://pve.proxmox.com/wiki/Qemu-guest-agent)

</p>

As it turns out, installing this is pretty easy. You install the service within your target VM, set the Agent option under hardware in the PVE web GUI to 'On', and then you reboot the VM.

</p>

Boom. Easy.

</p>

At this point you have better access to the guest through the API (either through the web or pvesh command on the host).

</p>

Now I'm not going to do into details about how long it took me to dig through the PVE API, but I found what I want.

</p>

[PVE APIv2 Docs!](http://pve.proxmox.com/pve-docs/api-viewer/index.html)

</p>

Dig down to nodes/{node}/qemu/{vmid}/agent - That's the API commands for querying the guest agent directly. Not a lot is implemented, however, network-get-interfaces looks promising.

</p>

(spoiler: that's what we want)

</p>

So playing around with pvesh on my VM host gets me to this command:

</p>

    pvesh create nodes/technodrome/qemu/101/agent -command network-get-interfaces(yes, my main node name is a reference to TMNT)

</p>

That returns a JSON response with all the network information on the interfaces on your guest:

</p>

    pvesh create nodes/technodrome/qemu/101/agent -command network-get-interfaces200 OK{  "result" : [    {      "hardware-address" : "00:00:00:00:00:00",      "ip-addresses" : [        {          "ip-address" : "127.0.0.1",          "ip-address-type" : "ipv4",          "prefix" : 8        },        {          "ip-address" : "::1",          "ip-address-type" : "ipv6",          "prefix" : 128        }      ],      "name" : "lo"    },    {      "hardware-address" : "<MAC address>",      "ip-addresses" : [        {          "ip-address" : "<ipv4 address",          "ip-address-type" : "ipv4",          "prefix" : 24        },        {          "ip-address" : "<ipv6 address>",          "ip-address-type" : "ipv6",          "prefix" : 64        }      ],      "name" : "eth0"    }  ]}sanitised so you can't see my internal numbering scheme

</p>

### OH SHIT. {#ohshit}

</p>

So, now the biggest obstacles I have are as follow:

</p>

-   Getting what I found into: <https://github.com/saltstack/salt/blob/develop/salt/cloud/clouds/proxmox.py>
    </p>

    -   Need to create a function `wait_for_ip_address()`
    -   Need to add some options to the Proxmox profile to handle being able to use DHCP

    </p>
-   Support having multiple interfaces that aren't lo
-   Get patch accepted into salt-cloud
    </p>

    -   (Or I just keep it for myself)

    </p>

</p>

### UPDATE, NERDS {#updatenerds}

</p>

So, as I've been working on the code for my patch to the proxmox provider, I was running some other solutions to my problem in my head.

</p>

Enter: [cloud-init](https://cloudinit.readthedocs.io/en/latest/)

</p>

What I've been realizing that I can do is use cloud-init to run a python scipt to set the hostname of the box.

</p>

-   Get the VMID of the VM
    </p>

    -   possibly use the MAC address as my unique identifier?

    </p>
-   Use VMID to call /qemu/{VMID}/status/current
-   Potentially use a shell script instead of a Python script to lower the amount of dependencies used

</p>

### Update 2, nerds {#update2nerds}

</p>

I think at this point I am going to eventually end up with the cloud-init solution. I think it's the easiest to support and it's [really](http://cloudinit.readthedocs.io/en/latest/topics/datasources/digitalocean.html) [interesting](http://cloudinit.readthedocs.io/en/latest/topics/datasources/ec2.html) [what](http://cloudinit.readthedocs.io/en/latest/topics/datasources/configdrive.html) [other](http://cloudinit.readthedocs.io/en/latest/topics/datasources/azure.html)  

clouds do.

</p>

I'm going to write my patch for the Proxmox provider, but probably just keep that fork as an example in my github account as something to show off. It'll be a fun exercise, but I don't see it as supportable  

beyond a stopgap until I get cloud-init working.

</p>

Plus, I'm pretty sure cloud-init will be a better solution for when I want to experiment with building LXC containers.

</p>

### Update 3, nerds {#update3nerds}

</p>

So, I've been neglecting my blog because I'm a dummy.

</p>

I've actually written my patch for the proxmox provider and have been using it in my homelab for a while at this point.

</p>

It was pretty cool, I got to learn how to do list comprehensions and now I can easily spin up new VMs in my lab!

</p>

<!--kg-card-end: markdown-->
