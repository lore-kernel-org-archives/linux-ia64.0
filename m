From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 24 Jan 2002 02:33:50 +0000
Subject: Re: [Linux-ia64] patch for vmlinux.lds.S
Message-Id: <marc-linux-ia64-105590698805921@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805920@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805920@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 23 Jan 2002 21:23:32 -0500, 
Bill Nottingham <notting@redhat.com> wrote:
>This fixes building the kernel for me; possibly a recent binutils
>thing? (Otherwise, I'm getting dangling references to the
>text.exit code in .IA_64.unwind.text.exit sections.)

Which binutils?

What does "objdump -h init/main.o vmlinux" report?


