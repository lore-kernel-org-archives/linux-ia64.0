From: Christoph Rohland <cr@sap.com>
Date: Tue, 25 Apr 2000 10:23:47 +0000
Subject: Re: [Linux-ia64] new kernel diff (relative to 2.3.99-pre5)
Message-Id: <marc-linux-ia64-105590678205036@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205032@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205032@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen <Jes.Sorensen@cern.ch> writes:

> Christoph> with 2.3.99-pre5 + your patch on my Lion. 2.3.52-0419 was
> Christoph> fine.
> 
> Did you by any chance use cp to copy it to a fat partition? There are
> known issues with cp, whereas 'cat vmlinux > /<dos-partition>/vmlinux'
> works fine.

Thanks, that did work...

Greetings
		Christoph


