From: Jes Sorensen <jes@sunsite.dk>
Date: Wed, 31 Oct 2001 23:16:21 +0000
Subject: Re: [Linux-ia64] C union on ia-64
Message-Id: <marc-linux-ia64-105590698805428@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805377@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805377@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "n0ano" = n0ano  <n0ano@indstorage.com> writes:

n0ano> Yeah, I know that NT uses a P64 model but if you'll look at the
n0ano> caption of the slide in question it is for `Linux Device
n0ano> Drivers'.  Anyone who typedef's `ULONG' to anything other than
n0ano> a 64-bit long on IA64 Linux deserves the confusion that that
n0ano> will create.

Actually, for Linux *nobody* should typedef ULONG or PVOID or any of
thos broken windows types to anything. Use the types as they are
named: `unsigned long', `void *' and use fixed sized types when fixed
sizes are needed: `u32', `u64', `s32' etc etc.

Promoting bogus typedefs is only going to make the code ugly,
unmaintainable and hard to debug.

Jes

