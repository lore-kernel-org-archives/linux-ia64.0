From: Petr Tesarik <ptesarik@suse.cz>
Date: Sun, 22 Jun 2008 19:13:36 +0000
Subject: Re: [PATCH] SN2: security hole in sn2_ptc_proc_write
Message-Id: <1214162016.17519.0.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1K9SIg-0005n6-Ea@eag09.americas.sgi.com>
In-Reply-To: <E1K9SIg-0005n6-Ea@eag09.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2008-06-22 at 20:58 +0200, Bernhard Walle wrote:
> * Andi Kleen <andi@firstfloor.org> [2008-06-22 19:41]:
> >
> > You need if (count < 0 || count > 64) me thinks.
> 
> size_t is unsigned.

Correct, that's why you need:

  if (count <= 0 || count > 64)

Cheers,
Petr Tesarik


