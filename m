From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 04 Jul 2001 00:25:26 +0000
Subject: Re: [Linux-ia64] Inquiry on the pre-processor
Message-Id: <marc-linux-ia64-105590693005817@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 3 Jul 2001 16:41:13 -0700, 
"Robboy, David G" <david.g.robboy@intel.com> wrote:
>What I want to do specifically is for ia32 assembly language, but the
>question is about preprocessing in general.  On certain assembly instruction
>opcodes, I want to suffix a macro that can be changed to the letter "b,"
>"w," or "l," so that a single source program can operate on different sized
>operands. 

#define OP_SUFFIX(op) (op##b)

Unfortunately ## only works inside macros so you have to write
OP_SUFFIX(op) instead of op##suffix.


