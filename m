From: "David S. Miller" <davem@davemloft.net>
Date: Wed, 08 Dec 2004 21:26:27 +0000
Subject: Re: Anticipatory prefaulting in the page fault handler V1
Message-Id: <20041208132627.1c73177e.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
	<20041202101029.7fe8b303.cliffw@osdl.org>
	<Pine.LNX.4.58.0412080920240.27156@schroedinger.engr.sgi.com>
	<200412080933.13396.jbarnes@engr.sgi.com>
	<Pine.LNX.4.58.0412080952100.27324@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412080952100.27324@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: jbarnes@engr.sgi.com, nickpiggin@yahoo.com.au, jgarzik@pobox.com, torvalds@osdl.org, hugh@veritas.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 8 Dec 2004 09:56:00 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> A patch like this is important for applications that allocate and preset
> large amounts of memory on startup. It will drastically reduce the startup
> times.

I see.  Yet I noticed that while the patch makes system time decrease,
for some reason the wall time is increasing with the patch applied.
Why is that, or am I misreading your tables?
