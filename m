From: Keith Owens <kaos@sgi.com>
Date: Wed, 12 Mar 2003 21:51:04 +0000
Subject: [Linux-ia64] Re: ia64_spinlock_contention and NEW_LOCK
Message-Id: <marc-linux-ia64-105590709806073@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806055@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806055@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 12 Mar 2003 09:27:14 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Wed, 12 Mar 2003 21:19:37 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> The inline code for an uncontended lock drops from 5 to 4
>  Keith> bundles for each use of spin_lock().  The uncontended path
>  Keith> has one less memory access.
>
>For McKinley and later, you can use brl to avoid the
>movl/indirect-branch combo.

That brings the uncontended code path down to 3 bundles :)


