From: Paul Jackson <pj@sgi.com>
Date: Thu, 27 Nov 2003 05:29:13 +0000
Subject: Re: [PATCH] check user access ok writing
Message-Id: <marc-linux-ia64-106991103102490@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David wrote:
> I see the problem, but the patch is incomplete: even after an
> access_ok()-check, you'll need to use __get_user() to access the
> buffer.

Right you are.  Too bad.  Just bolting an access_ok() on the
front of this code let me get away with not messing with the
existing code.

Keeping patches minimal is easier if they don't have to work ;).

As long as I have to mess with the 'R' parsing code anyway,
might as well use copy_from_user() and clean up these few lines
of code as best I can.

Another patch will be forthcoming.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
