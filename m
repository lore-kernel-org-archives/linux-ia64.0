From: Andreas Schwab <schwab@suse.de>
Date: Fri, 05 Nov 2004 16:26:10 +0000
Subject: Re: Externalize SLIT table
Message-Id: <jevfcknty5.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041103205655.GA5084@sgi.com>
	<20041104.105908.18574694.t-kochi@bq.jp.nec.com>
	<20041104040713.GC21211@wotan.suse.de>
	<20041104.135721.08317994.t-kochi@bq.jp.nec.com>
	<20041105160808.GA26719@sgi.com>
In-Reply-To: <20041105160808.GA26719@sgi.com> (Jack Steiner's message of
 "Fri, 5 Nov 2004 10:08:08 -0600")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Jack Steiner <steiner@sgi.com>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>, ak@suse.de, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Jack Steiner <steiner@sgi.com> writes:

> @@ -111,6 +111,21 @@ static ssize_t node_read_numastat(struct
>  }
>  static SYSDEV_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
> =20
> +static ssize_t node_read_distance(struct sys_device * dev, char * buf)
> +{
> +	int nid =3D dev->id;
> +	int len =3D 0;
> +	int i;
> +
> +	for (i =3D 0; i < numnodes; i++)
> +		len +=3D sprintf(buf + len, "%s%d", i ? " " : "", node_distance(nid, i=
));

Can this overflow the space allocated for buf?

> @@ -58,6 +59,31 @@ static inline void register_cpu_control(
>  }
>  #endif /* CONFIG_HOTPLUG_CPU */
> =20
> +#ifdef CONFIG_NUMA
> +static ssize_t cpu_read_distance(struct sys_device * dev, char * buf)
> +{
> +	int nid =3D cpu_to_node(dev->id);
> +	int len =3D 0;
> +	int i;
> +
> +	for (i =3D 0; i < num_possible_cpus(); i++)
> +		len +=3D sprintf(buf + len, "%s%d", i ? " " : "",=20
> +			node_distance(nid, cpu_to_node(i)));

Or this?

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
