From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 11 Mar 2003 22:40:37 +0000
Subject: Re: [Linux-ia64] 2.4.20 / DIG
Message-Id: <marc-linux-ia64-105590709806036@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806024@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806024@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Bjorn" = Bjorn Helgaas <bjorn_helgaas@hp.com> writes:

>>  Must admit I didn't - are those preserved across a power cycle?

Bjorn> They should be.  Of course, it will only make sense if you still
Bjorn> have symbols from the kernel that caused the MCA.

Urgh, brown paper bag time ... I was running a very old version of EFI
on it (103B). Upgrading to 117C made the problem go away, the proper way.

Doh ;-( sorry for the noise.

Cheers,
Jes

