From: Jes Sorensen <Jes.Sorensen@cern.ch>
Date: Tue, 25 Apr 2000 09:50:44 +0000
Subject: Re: [Linux-ia64] new kernel diff (relative to 2.3.99-pre5)
Message-Id: <marc-linux-ia64-105590678205035@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205032@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205032@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Christoph" = Christoph Rohland <hans-christoph.rohland@sap.com> writes:

Christoph> Hi David, I get:

[snip]

Christoph> with 2.3.99-pre5 + your patch on my Lion. 2.3.52-0419 was
Christoph> fine.

Did you by any chance use cp to copy it to a fat partition? There are
known issues with cp, whereas 'cat vmlinux > /<dos-partition>/vmlinux'
works fine.

I just booted it here and it worked fine.

Jes


