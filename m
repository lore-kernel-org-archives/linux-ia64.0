From: Diego Calleja <diegocg@teleline.es>
Date: Mon, 08 Nov 2004 16:57:10 +0000
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-Id: <20041108175710.72e76064.diegocg@teleline.es>
List-Id: <linux-ia64.vger.kernel.org>
References: <4189EC67.40601@yahoo.com.au>
	<226170000.1099843883@[10.10.2.4]>
	<Pine.LNX.4.58.0411080800020.7996@schroedinger.engr.sgi.com>
	<200411081730.37906.efocht@hpce.nec.com>
In-Reply-To: <200411081730.37906.efocht@hpce.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Erich Focht <efocht@hpce.nec.com>
Cc: clameter@sgi.com, mbligh@aracnet.com, nickpiggin@yahoo.com.au, benh@kernel.crashing.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org

El Mon, 8 Nov 2004 17:30:37 +0100 Erich Focht <efocht@hpce.nec.com> escribi=
=F3:

> You're talking about clusters, i.e. multiple running instances of the
> operating system. I don't think anybody really wants to go far beyond
> 512 nowadays. Application-wise 512 cpus/node isn't really needed (but

<the newspaper guy>

SGI is already building one of 1024 CPUs according to some sources:
http://www.computerworld.com/hardwaretopics/hardware/story/0,10801,94564,00=
.html

but...

"Initially, Pennington said, the system will use two images of Linux -- one
per 512 processors -- while it's being tested and configured. Later, all 1,=
024
processors will address one image of the SGI Advanced Linux operating system
being used."

Also here ->
http://www.sgi.com/company_info/newsroom/press_releases/2004/november/jaeri=
.html
it talks about another supercomputer of 2048 CPUs, but I don't find clear
if it's a cluster, or several images.=20
