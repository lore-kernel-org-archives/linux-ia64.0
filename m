From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Fri, 18 May 2001 17:17:56 +0000
Subject: Re: [Linux-ia64] GUID filesystem+device identification ?
Message-Id: <marc-linux-ia64-105590693005622@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005620@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005620@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Having it in ther kernel would be nicer and shouldn't be that difficult,
> on the other hand it'll need a consensus on wether the kernel should look
> at every partition on startup - IIRC some people where opposed to such
> soloutions in the past.
>

The kernel looks at partition type GUID of all partitions already
(in fs/partitions/efi.c), all it would need to do apart from that
look at the Unique GUID as well and create a GUID->device
table somewhere.

Cheers, Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




