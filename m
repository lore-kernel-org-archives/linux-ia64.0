From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 14 Jun 2001 23:51:26 +0000
Subject: Re: [Linux-ia64] breakpoint function using kdb
Message-Id: <marc-linux-ia64-105590693005735@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005733@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005733@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 14 Jun 2001 14:32:45 -0500, 
"Sherbert, Shannon" <Shannon.Sherbert@COMPAQ.com> wrote:
>Is there a breakpoint function that can be compiled into a module, so that
>when that function is executed kdb is entered?  I guess sort of like an
>"int13" in ia32.

KDB_ENTER();


