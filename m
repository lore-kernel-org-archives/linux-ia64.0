From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 23 Feb 2005 08:12:08 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <yq0wtszeluv.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
	<1109109833.6024.109.camel@laptopd505.fenrus.org>
	<yq04qg4i5wu.fsf@jaguar.mkp.net>
	<1109112142.6024.119.camel@laptopd505.fenrus.org>
In-Reply-To: <1109112142.6024.119.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arjan van de Ven <arjan@infradead.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> "Arjan" = Arjan van de Ven <arjan@infradead.org> writes:

Arjan> On Tue, 2005-02-22 at 17:30 -0500, Jes Sorensen wrote:
>>  For userspace it's used by some of the MPI type apps in userland.

Arjan> you got to be kidding. Why are these MPI apps accessing memory
Arjan> that the kernel has mapped cached (eg ram) via /dev/mem?

Oh sorry, I think  we're misunderstanding eachother. /dev/mem is used
by lcrash.

Arjan> (eg my proposal is to make /dev/mem to be just device memory
Arjan> not kernel accessable ram; wouldn't that solve the entire issue
Arjan> cleanly ?)

It would kill lcrash support, but sure it would solve this specific
problem. However what happens if someone wants to share say some
texture ram between the kernel and a video card and that has to be
mapped uncached? Though up example here though.

Cheers,
Jes

