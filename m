From: Duraid Madina <duraid@octopus.com.au>
Date: Wed, 21 May 2003 10:40:36 +0000
Subject: Re: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723705969@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dear Arjan,


       ///////
       //    O
      //      >                                    This is a graduate
       / \__ ~                                     student, laboratory
         ||                            /////       assistant, automotive
       (\ \)   (~)                    //  o   <--- engineer or other
       ( \ \  / /                    //    >       unfortunate soul
       (  \ \/ /         ____________/ \__O        attempting to get
       (   \__/         /  ___ ______\//           performance out of a
       /   | /@        (  /  / ______)/            machine running Linux
      (    |//          \ \ / /   (_)              by writing a simple
       \   ()            \ \O/                     and correct
        \  |              ) )                      multithreaded program.
         ) )             / /
        (  |_           / /_
        (____>         (____>

           ^
           |
           |
           |
           |

      This is you.



	(with apologies to the haxor brothers,)

	Duraid.


Arjan van de Ven wrote:
 > oh you mean the OpenMP broken behavior of calling sched_yield() in a
 > tight loop to implement spinlocks ?



