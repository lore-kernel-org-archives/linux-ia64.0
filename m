From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 14 Mar 2002 14:20:46 +0000
Subject: Re: [Linux-ia64] seldom insmod error
Message-Id: <marc-linux-ia64-105590701905281@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905279@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905279@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 14 Mar 2002 15:00:29 +0100, 
Christian Hildner <christian.hildner@hob.de> wrote:
>Hi!
>
>When doing insmod on my module I get the following error message:
>
>insmod: obj_ia64.c:258: obj_ia64_ins_imm64: Assertion 'slot = 1'
>failed.
>Aborted

Upgrade to modutils 2.4.14.


