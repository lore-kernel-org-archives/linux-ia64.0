From: Dan Pop <Dan.Pop@cern.ch>
Date: Thu, 07 Jun 2001 13:20:21 +0000
Subject: Re: [Linux-ia64] RPC on IA64
Message-Id: <marc-linux-ia64-105590693005694@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005693@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005693@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Thu, 7 Jun 2001, qiuhb wrote:

> The long type is 32-bit on IA32 and it is 64-bit on IA64,yes or no?

Yes.  Nowadays, long is the only standard C type whose size is likely
to vary between platforms.  int is 32-bit practically everywhere and
long long is 64-bit everywhere.  Note that the current situation *may*
change in the future, so it's better to avoid relying on these sizes,
if possible.

Dan


