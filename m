From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 04 Nov 2002 23:03:48 +0000
Subject: Re: [Linux-ia64] linuxthread stack problem
Message-Id: <marc-linux-ia64-105590709805331@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805328@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805328@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 04 Nov 2002 12:43:46 -0600, Philip Armstrong <pma@sgi.com> said:

  Philip> While in the same subroutine, however, the ordering of the
  Philip> pthread_cleanup_buffer stack addresses as allocated by the
  Philip> pthread_cleanup_push macro is indeterminate, at least it is
  Philip> on our IA64 platform.

  Philip> I have simplified the problem into a short test case that
  Philip> uses the bracketing and stack address allocation in the same
  Philip> manner that the pthread_cleanup_push() and
  Philip> pthread_cleanup_pop() macros do. In my case, we have
  Philip> STACK_GROW_DOWN defined, and as you can see the second stack
  Philip> address is actually greater than the first. The
  Philip> pthread_cancel routine would not execute the second cleanup
  Philip> subroutine put on the stack in this case becuase the address
  Philip> comparison (FRAME_LEFT in linuxthreads/cancel.c) would
  Philip> prohibit it.

You also might want to send this question to one of the gcc mailing
lists.

	--david

