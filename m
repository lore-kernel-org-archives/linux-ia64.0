From: Bill Nottingham <notting@redhat.com>
Date: Fri, 05 Dec 2003 02:37:46 +0000
Subject: Re: can't boot 2.6.0-test11
Message-Id: <marc-linux-ia64-107059221220956@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107057525104512@msgid-missing>
In-Reply-To: <marc-linux-ia64-107057525104512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger (davidm@napali.hpl.hp.com) said: 
>   Bill> Comparing readelf output, one big difference is where it loads
>   Bill> the percpu data segment:
> 
> That should be OK though.  elilo only ever looks at the physical addresses.
> Do you have a stale version of elilo by chance?

No, 3.4.

Bill
