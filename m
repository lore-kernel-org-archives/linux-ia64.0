From: Erich Focht <efocht@hpce.nec.com>
Date: Mon, 08 Nov 2004 17:26:16 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <200411081826.16550.efocht@hpce.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4189EC67.40601@yahoo.com.au> <200411081730.37906.efocht@hpce.nec.com> <20041108175710.72e76064.diegocg@teleline.es>
In-Reply-To: <20041108175710.72e76064.diegocg@teleline.es>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Diego Calleja <diegocg@teleline.es>
Cc: clameter@sgi.com, mbligh@aracnet.com, nickpiggin@yahoo.com.au, benh@kernel.crashing.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Monday 08 November 2004 17:57, Diego Calleja wrote:
> El Mon, 8 Nov 2004 17:30:37 +0100 Erich Focht <efocht@hpce.nec.com> escri=
bi=F3:
>=20
> > You're talking about clusters, i.e. multiple running instances of the
> > operating system. I don't think anybody really wants to go far beyond
> > 512 nowadays. Application-wise 512 cpus/node isn't really needed (but
>=20
> <the newspaper guy>
>=20
> SGI is already building one of 1024 CPUs according to some sources:
> http://www.computerworld.com/hardwaretopics/hardware/story/0,10801,94564,=
00.html
>=20
> but...
>=20
> "Initially, Pennington said, the system will use two images of Linux -- o=
ne
> per 512 processors -- while it's being tested and configured. Later, all =
1,024
> processors will address one image of the SGI Advanced Linux operating sys=
tem
> being used."

1k is not really "far beyond" 512. I'm sure it's doable, but I doubt
that this (or bigger machines) will spread too much. The progress in
cluster interconnect technology and software is just too fast. Think
of price/performance and stability (MTBF accumulation) and judge
yourself. Sure, if Linux could survive breaking hardware, the story
might change.

> Also here ->
> http://www.sgi.com/company_info/newsroom/press_releases/2004/november/jae=
ri.html
> it talks about another supercomputer of 2048 CPUs, but I don't find clear
> if it's a cluster, or several images.=20

That was advertised to be a fraction of the Columbia machine, so a
cluster of big machines.

Erich

