From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Fri, 01 Jan 2021 15:30:04 +0000
Subject: Re: [PATCH] sh: add support for TIF_NOTIFY_SIGNAL
Message-Id: <f95539e9-506b-c4d9-2861-f288e2d021df@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <5fcc82b4-89ae-3bca-10ab-6ad933565cee@kernel.dk>
 <ae29ab73-ee7a-2bb7-3fd8-3037f40c1cbd@kernel.dk>
 <5611bde9-67e7-6ff6-defc-9b02ea830fac@physik.fu-berlin.de>
 <9ea14eb3-d698-5499-ba4c-c6a3c35cd8d4@kernel.dk>
 <47f79645-53b7-b11c-167a-f5721b53df02@physik.fu-berlin.de>
 <9d9acec6-1e8c-2d68-5dfa-d58c11cf5cc4@kernel.dk>
 <070780c4-445e-6373-c8f4-1c72d0f3b4e0@physik.fu-berlin.de>
 <1047f3e5-4599-c34f-3176-9f41d2e1246b@kernel.dk>
 <31b34cfc-8d6e-d3b4-e29f-1ec485f5b368@physik.fu-berlin.de>
 <23bf4423-0987-c445-d5cd-1922e1e40820@kernel.dk>
In-Reply-To: <23bf4423-0987-c445-d5cd-1922e1e40820@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-sh@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Hi Jens!

On 1/1/21 4:08 PM, Jens Axboe wrote:
> On 1/1/21 7:06 AM, John Paul Adrian Glaubitz wrote:
>> Is there away to test the change itself?
> 
> The only user of TWA_SIGNAL, which uses TIF_NOTIFY_SIGNAL, so far is io_uring.
> You need something that triggers deferred task_work processing, which is
> basically anything that ends up being poll driven for data/space readiness.
> Here's a small test app from the liburing test suite, that'll trigger it.
> 
> If you install liburing, compile with:
> 
> gcc -Wall -O2 -o socket-rw socket-rw.c -luring
> 
> and run it without any arguments.

How long is this test supposed to run? It's already been running for some minutes
on my 600 MHz machine.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
