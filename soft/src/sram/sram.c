#include <stdint.h>

#define UART_BASE_ADDRESS 0x1000000

void putch(char ch)
{
  *((volatile char*)UART_BASE_ADDRESS) = ch;
}

void print(int num)
{
  if (num<0)
  {
    putch('-');
    num = -num;
  }
  if (num/10)
  {
    print(num/10);
  }
  putch(num%10 + '0');
}

void set_matrix(int n,int m,int mat[n][m],int val)
{
  for (int i=0; i<n; i++)
  {
    for (int j=0; j<m; j++)
    {
      mat[i][j] = val;
    }
  }
}

void print_matrix(int n,int m,int mat[n][m])
{
  for (int i=0; i<n; i++)
  {
    for (int j=0; j<m; j++)
    {
      print(mat[i][j]);
      putch(' ');
    }
    putch('\n');
  }
  putch('\n');
}

void matrix_mult(int n,int m,int o,int mat_l[n][m],int mat_r[m][o],int mat_e[n][o])
{
  for (int i=0; i<n; i++)
  {
    for (int j=0; j<o; j++)
    {
      mat_e[i][j] = 0;
      for (int k=0; k<m; k++)
      {
        mat_e[i][j] += mat_l[i][k]*mat_r[k][j];
      }
    }
  }
}

int matrix_norm(int n,int m,int mat_l[n][m],int mat_r[n][m])
{
  int norm = 0;
  for (int i=0; i<n; i++)
    for (int j=0; j<m; j++)
      norm += (mat_l[i][j]-mat_r[i][j])*(mat_l[i][j]-mat_r[i][j]);
  return norm;
}

int main()
{
  int K = 10;
  int L = 20;
  int M = 30;

  int norm = 0;

  int A[K][L];
  int B[L][M];
  int C[K][M];
  int D[K][M];

  set_matrix(K,L,A,1);
  set_matrix(L,M,B,1);
  set_matrix(K,M,C,L);

  matrix_mult(K,L,M,A,B,D);

  norm = matrix_norm(K,M,C,D);

  print_matrix(K,L,A);
  print_matrix(L,M,B);
  print_matrix(K,M,C);
  print_matrix(K,M,D);

  putch('N');
  putch('o');
  putch('r');
  putch('m');
  putch(':');
  putch(' ');
  print(norm);
  putch('\n');

  while(1);
}
