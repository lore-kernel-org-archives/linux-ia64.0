From: Martin Pool <mbp@sourcefrog.net>
Date: Tue, 26 Aug 2003 00:28:47 +0000
Subject: Re: [patch] turn off CONFIG_FD on ia64?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="W,Fh,24+g=.t3_rg"
Message-Id: <marc-linux-ia64-106185788101534@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106015002132453@msgid-missing>
In-Reply-To: <marc-linux-ia64-106015002132453@msgid-missing>
To: linux-ia64@vger.kernel.org

--W,Fh,24+g=.t3_rg
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On 25 Aug 2003 05:30:30 -0400
Jes Sorensen <jes@wildopensource.com> wrote:

> >>>>> "Christoph" == Christoph Hellwig <hch@infradead.org> writes:
> 
> Christoph> Anyway, we should test explicitly for configurations
> Christoph> supported by floppy.c.  So far this would be:
> 
> Christoph> CONFIG_ISA CONFIG_M68K CONFIG_SPARC
> 
> CONFIG_SPARC64 I believe. No idea about MIPS configurations.

Should I send a patch to turn off architectures which will never work? 
(Who to?)  It seems to me that allowing people to turn on options which
don't build is not very helpful.

-- 
Martin 

GNU does not eliminate all the world's problems, only some of them.
		-- The GNU Manifesto

--W,Fh,24+g=.t3_rg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/SqnBPGPKP6Cz6IsRAkeyAJ4yIAqc7e7oLmimSQiQ2OqPS3syGgCfUx+5
LYL4OAe4j7pgrLgrr9Tt7Ug=
=CxB+
-----END PGP SIGNATURE-----

--W,Fh,24+g=.t3_rg--
