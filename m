From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 11 Jul 2002 09:52:38 +0000
Subject: [Linux-ia64] Re: O(1) scheduler "complex" macros
Message-Id: <marc-linux-ia64-105590701905755@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905752@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905752@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

the correct macro is:

  #define task_running(rq, p) \
 	(((rq)->curr = (p)) || spin_is_locked(&(p)->switch_lock))

	Ingo


