From: Andreas Schwab <schwab@suse.de>
Date: Mon, 20 Oct 2003 20:50:16 +0000
Subject: Re: [PATCH] fix topology init take 2
Message-Id: <marc-linux-ia64-106668311200755@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641524132220@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641524132220@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

jbarnes@sgi.com (Jesse Barnes) writes:

> @@ -43,3 +50,49 @@
> =20
>  	return (i < num_memblks) ? node_memblk[i].nid : (num_memblks ? -1 : 0);
>  }
> +
> +static int __init topology_init(void)
> +{
> +	int i, err =3D 0;
> +
> +	sysfs_nodes =3D kmalloc(sizeof(struct node) * numnodes, GFP_KERNEL);
> +	if (!sysfs_nodes) {
> +		err =3D -ENOMEM;
> +		goto out;
> +	}
> +
> +	sysfs_memblks =3D kmalloc(sizeof(struct memblk) * num_memblks,
> +				GFP_KERNEL);
> +	if (!sysfs_memblks) {
> +		kfree(sysfs_nodes);
> +		err =3D -ENOMEM;
> +		goto out;
> +	}
> +
> +	sysfs_cpus =3D kmalloc(sizeof(struct cpu) * NR_CPUS, GFP_KERNEL);
> +	if (!sysfs_cpus) {
> +		kfree(sysfs_memblks);
> +		kfree(sysfs_nodes);
> +		err =3D -ENOMEM;
> +		goto out;
> +	}
> +
> +	for (i =3D 0; i < numnodes; i++)
> +		if ((err =3D register_node(&sysfs_nodes[i], i, 0)))
> +			goto out;
> +=09
> +	for (i =3D 0; i < num_memblks; i++)
> +		if ((err =3D register_memblk(&sysfs_memblks[i], i,
> +					   &sysfs_nodes[memblk_to_node(i)])))
> +			goto out;
> +=09
> +	for (i =3D 0; i < NR_CPUS; i++)
> +		if (cpu_online(i))
> +			if((err =3D register_cpu(&sysfs_cpus[i], i,
> +					       &sysfs_nodes[cpu_to_node(i)])))
> +				goto out;

You need to clear all kmalloc'd memory before you can pass it to
register_{node,memblk,cpu}, otherwise sys_device_register may trip over
the uninitialized sysdev.

--- linux-2.6.0-test8/arch/ia64/mm/numa.c.~1~	2003-10-20 21:25:23.000000000=
 +0200
+++ linux-2.6.0-test8/arch/ia64/mm/numa.c	2003-10-20 22:00:21.000000000 +02=
00
@@ -76,6 +76,9 @@ static int __init topology_init(void)
 		err =3D -ENOMEM;
 		goto out;
 	}
+	memset(sysfs_nodes, 0, sizeof(struct node) * numnodes);
+	memset(sysfs_memblks, 0, sizeof(struct memblk) * num_memblks);
+	memset(sysfs_cpus, 0, sizeof(struct cpu) * NR_CPUS);
=20
 	for (i =3D 0; i < numnodes; i++)
 		if ((err =3D register_node(&sysfs_nodes[i], i, 0)))

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
