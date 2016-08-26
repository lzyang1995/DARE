#include <stdio.h>
#include <inttypes.h>
#include <stdint.h>

int main(int argc, char const *argv[])
{
	FILE *fp = fopen(argv[1], "r");
	int i, read;
	int min = 10000;
	int max = 0;
	double sum = 0;

	for(i = 0;i < 20000;i++)
	{
		fscanf(fp, "%d", &read);

		sum += read;

		if(read < min)
			min = read;

		if(read > max)
			max = read;
	}

	printf("max: %d\n", max);
	printf("min: %d\n", min);
	printf("avg: %lf\n", sum/20000);

	return 0;
}