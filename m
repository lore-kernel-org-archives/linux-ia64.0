From: John Baboval <baboval@mclinux.com>
Date: Tue, 22 Aug 2000 18:49:57 +0000
Subject: [Linux-ia64] Memory clearing at reboot
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
Message-Id: <marc-linux-ia64-105590678205378@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I have a small test program that I run at the EFI shell prompt to set an
area of memory and then perform a warm reboot. After the reboot our BigSur
still contains the values written, but the Lion is cleared to zero. (We
check the contents with the mem command, and the ResetSystem() is called
with the EfiResetWarm parameter.)

Does anyone know if there is a way to cause the Lion *not* to clear memory?
Also, our Lion has newer firmware then the BigSur. Perhaps the newer
firmware causes the reset? 

If someone out there has a BigSur with the latest firmware/CPU rev., could
you run my program and tell me if your machine resets it's memory? The
source code is attached, and you can build it with gnu-efi-0.9.

Basically, you run the program and write down the address, and then when the
machine comes back up type 'mem <Address>' and see if the memory is zero or
not.

Not reseting memory makes taking kernel core dumps with our in-memory core
dump patches MUCH easier! Thanks for any help,

-- 
--John
jbaboval@missioncriticallinux.com

--ZGiS0Q5IWpPtfppv
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="set_reset.c"

#include <efi.h>
#include <efilib.h>

EFI_STATUS
efi_main (EFI_HANDLE image, EFI_SYSTEM_TABLE *systab)
{
	unsigned long bytes, mbytes;
	CHAR16 *prompt = W2U(L"Enter number of Mbytes: ");
	CHAR16 input[255];
	int input_len = 255;
	void *buffer;
	EFI_STATUS status;
	unsigned long i;
	long *temp;
	CHAR16 *ugh = W2U(L"test");

	InitializeLib(image, systab);

	Input(prompt, input, input_len);
	mbytes = Atoi(input);
	bytes = mbytes*1024*1024;

	Print (W2U(L"\nAllocating pool of %d bytes\n"), bytes);
	status = BS->AllocatePool(EfiBootServicesData, bytes, &buffer);

	if(status != EFI_SUCCESS) {
		Print(W2U(L"AllocatePool Failed with "));
		switch(status) {
			case EFI_OUT_OF_RESOURCES:
				Print(W2U(L"EFI_OUT_OF_RESOURCES\n"));
				break;
			case EFI_INVALID_PARAMETER:
				Print(W2U(L"EFI_INVALID_PARAMETER\n"));
				break;
			default:
				Print(W2U(L"%d\n"), status);
		}
		return status;
	}

	Print(W2U(L"Allocation succeeded. Buffer start :%016x\n"), buffer);

	Print(W2U(L"Setting Memory to 0xDEADBEEF"));
	for(i=0; i<bytes/8; i++) {
		temp = (long *)(buffer + i*8);
		*temp = (0xEFBEADDEEFBEADDE);
		if(((i*8)%(1024*1024)) == 0)
			Print(W2U(L"."));
	}

	Print(W2U(L"Press any key to reboot\n"));
        WaitForSingleEvent(ST->ConIn->WaitForKey, 0);
	RT->ResetSystem(EfiResetWarm, EFI_SUCCESS, 0, NULL);
		
	return EFI_SUCCESS;
}

--ZGiS0Q5IWpPtfppv--

