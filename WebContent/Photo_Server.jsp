<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<%@ page import="com.oreilly.servlet.*"%>
<%@ page import="com.oreilly.servlet.multipart.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Insert title here</title>
</head>
<body>
<%

	MultipartRequest multi = new MultipartRequest(request,"C:\\Upload", 5*1024*1024, "utf-8", new DefaultFileRenamePolicy());

	String tmp;
	String algo = multi.getParameter("algo");
	String para = multi.getParameter("para");

	Enumeration files = multi.getFileNames();
	tmp=(String) files.nextElement();
	String fileName = multi.getFilesystemName(tmp);
	
	// 영상처리 프로그램 기본 처리
	// lena256.raw 파일을 읽어서, 영상처리 알고리즘에 의해서 처리한후, 결과를 저장하기..
	// (1) JSP에서 파일 처리
	int inW, inH, outW=0, outH=0;

	File inFp;
	FileInputStream inFs;
	inFp = new File("C:/Upload/"+fileName);
	
	//파일 크기 가져오기
	long fLen=inFp.length();
	inH=inW=(int)Math.sqrt(fLen);
	
	inFs = new FileInputStream(inFp.getPath());
	// (2) JSP에서 배열 처리
	int[][]  inImage = new int[inH][inW]; // 메모리 할당
	// 파일 --> 메모리
	for (int i=0; i<inH; i++) {
		for (int k=0; k<inW; k++) {
			inImage[i][k] = inFs.read();
		}
	}
	inFs.close();
	
	int[][] outImage=null;
	
	switch (algo){
		case "1" : //반전하기
			// (3) 알고리즘을 적용하기...
			// 반전 알고리즘 :  out = 255 - in
			// (중요!) 출력영상의 크기 결정 --> 알고리즘에 의존
			outH = inH;
			outW = inW;
			// 메모리 할당
			outImage = new int[outH][outW];
			// 진짜 영상처리 알고리즘
			for(int i=0; i<inH; i++)
				for (int k=0; k<inW; k++) {
					outImage[i][k] = 255 - inImage[i][k];
				}
			break;
		case "2" : //밝게하기
			// (3) 알고리즘을 적용하기...
			// 밝게하기 알고리즘 :  out = in + 값(오버플로우 주의)
			// (중요!) 출력영상의 크기 결정 --> 알고리즘에 의존
			outH = inH;
			outW = inW;
			// 메모리 할당
			outImage = new int[outH][outW];
			// 진짜 영상처리 알고리즘
			for(int i=0; i<inH; i++)
				for (int k=0; k<inW; k++) {
					outImage[i][k] = inImage[i][k] + Integer.parseInt(para);
					if(outImage[i][k] >255)
						outImage[i][k]=255;
				}
			break;
		case "3" : //어둡게하기
			outH = inH;
			outW = inW;
			// 메모리 할당
			outImage = new int[outH][outW];
			// 진짜 영상처리 알고리즘
			for(int i=0; i<inH; i++)
				for (int k=0; k<inW; k++) {
					outImage[i][k] = inImage[i][k] - Integer.parseInt(para);
					if(outImage[i][k] < 0)
						outImage[i][k]=0;
				}
			break;
		case "4" : //x,y축 이동하기
			outH = inH;
			outW = inW;

			//메모리 할당
			outImage = new int[outH][outW];

			// 진짜 영상처리 알고리즘
			for(int i=0; i<inH; i++)
				for(int k=0; k<inW; k++){
					if(i<Integer.parseInt(para)||k<Integer.parseInt(para))
						outImage[i][k]=0;
					else if(i+Integer.parseInt(para)<outW && k+Integer.parseInt(para)<outH)
						outImage[i+Integer.parseInt(para)][k+Integer.parseInt(para)]=inImage[i][k];
				}
			break;
		case "5" : //확대하기
			outH = inH*Integer.parseInt(para);
			outW = inW*Integer.parseInt(para);

			//메모리 할당
			outImage = new int[outH][outW];
			// 진짜 영상처리 알고리즘
			for(int i=0; i<inH*Integer.parseInt(para); i++)
				for(int k=0; k<inW*Integer.parseInt(para); k++){
					outImage[i][k]=inImage[i/Integer.parseInt(para)][k/Integer.parseInt(para)];
				}
			break;
		case "6" : //축소하기
			outH = inH/Integer.parseInt(para);
			outW = inW/Integer.parseInt(para);

			//메모리 할당
			outImage = new int[outH][outW];
			// 진짜 영상처리 알고리즘
			for(int i=0; i<inH/Integer.parseInt(para); i++)
				for(int k=0; k<inW/Integer.parseInt(para); k++){
					outImage[i][k]=inImage[i*Integer.parseInt(para)][k*Integer.parseInt(para)];
				}
			break;
		case "7" : //회전하기
			outH = inH;
			outW = inW;

			//메모리 할당
			outImage = new int[outH][outW];

			// 진짜 영상처리 알고리즘
			double radian=Integer.parseInt(para)*Math.PI/180.0;
			radian = -radian;

			//xd=cos*xs - sin*ys
			//yd=sin*xs + cos*ys
			int xd, yd, xs, ys;
			int cx=inH/2;
			int cy=inW/2;

			for(int i=0; i<outH; i++)
				for(int k=0; k<outW; k++){
					xs=i;
					ys=k;
					xd=(int)(Math.cos(radian)*(xs-cx)-Math.sin(radian)*(ys-cy)+cx);
					yd=(int)(Math.sin(radian)*(xs-cx)+Math.cos(radian)*(ys-cy)+cy);
					
					//회전 이후의 위치가 출력영상의 범위안에 있는지
					if((0<=xd&&xd <outH) &&(0<=yd&&yd<outW))
						outImage[xs][ys]=inImage[xd][yd];
					else
						outImage[xs][ys]=255;
				}
			break;
		case "8" : //엠보싱
			outH = inH;
			outW = inW;

			//메모리 할당
			outImage = new int[outH][outW];

			//화소영역처리
			int mask[][] = {{-1, 0, 0},
							{0, 0, 0},
							{0, 0, 1}};
			//임시 입력 배열 생성
			int [][] tempInImage=new int[inH+2][inW+2];
			//임시 입력 배열에 입력 배열 데이터 입력
			for(int i=0; i<inH; i++){
				for(int k=0; k<inW; k++){
					tempInImage[i][k] = inImage[i][k];
				}
			}
			// 임시 출력 배열 생성
			int[][] tempOutImage=new int[outH][outW];

			// 영상처리알고리즘
			// 진짜 영상처리 알고리즘
			for(int i=0; i<inH; i++){
				for(int k=0; k<inW; k++){
					int S =0;
					for(int m=0; m<3; m++){
						for( int n=0; n<3; n++){
							S += mask[m][n] * tempInImage[i+m][k+n];
						}
					}
					tempOutImage[i][k] = S;
				}
			}

			//마스크 합계 0일때 중간값으로 바꿔주기(너무 어두워서 안보일수 있으니)
			for(int i=0; i<outH; i++)
				for(int k=0; k<outW; k++)
					tempOutImage[i][k] +=127;

			//임시출력배열에서 진짜 출력배열로 복사
			for(int i=0; i<outH; i++)
				for(int k=0; k<outW; k++){
					int v = tempOutImage[i][k];
					
					if(tempOutImage[i][k]>255)
						tempOutImage[i][k]=255;
					if(tempOutImage[i][k]<0)
						tempOutImage[i][k]=0;
					outImage[i][k] = tempOutImage[i][k];
				}
			break;
		case "9" : //블러링
			outH = inH;
			outW = inW;

			//메모리 할당
			outImage = new int[outH][outW];

			//화소영역처리
			double mask2[][] = {{1.0/9.0, 1.0/9.0, 1.0/9.0},
							{1.0/9.0, 1.0/9.0, 1.0/9.0},
							{1.0/9.0, 1.0/9.0, 1.0/9.0}};
			//임시 입력 배열 생성
			int [][] tempInImage2=new int[inH+2][inW+2];
			//임시 입력 배열에 입력 배열 데이터 입력
			for(int i=0; i<inH; i++){
				for(int k=0; k<inW; k++){
					tempInImage2[i][k] = inImage[i][k];
				}
			}
			// 임시 출력 배열 생성
			int[][] tempOutImage2=new int[outH][outW];

			// 영상처리알고리즘
			// 진짜 영상처리 알고리즘
			for(int i=0; i<inH; i++){
				for(int k=0; k<inW; k++){
					double S =0.0;
					for(int m=0; m<3; m++){
						for( int n=0; n<3; n++){
							S += mask2[m][n] * tempInImage2[i+m][k+n];
						}
					}
					tempOutImage2[i][k] = (int)S;
				}
			}

			//마스크 합계 0일때 중간값으로 바꿔주기(너무 어두워서 안보일수 있으니)
			for(int i=0; i<outH; i++)
				for(int k=0; k<outW; k++)
					if(tempOutImage2[i][k]<0)
						tempOutImage2[i][k] +=127;

			//임시출력배열에서 진짜 출력배열로 복사
			for(int i=0; i<outH; i++)
				for(int k=0; k<outW; k++){
					if(tempOutImage2[i][k]>255)
						tempOutImage2[i][k]=255;
					if(tempOutImage2[i][k]<0)
						tempOutImage2[i][k]=0;
					outImage[i][k] = tempOutImage2[i][k];
				}
			break;
		
	}
	
	// (4) 결과를 파일로 쓰기
	File outFp;
	FileOutputStream outFs;
	String OutFname = "out_" + fileName;
	outFp = new File("C:/Out/"+OutFname);
	outFs = new FileOutputStream(outFp.getPath());

	// 메모리 --> 파일
	for (int i=0; i<outH; i++) {
		for (int k=0; k<outW; k++) {
			outFs.write(outImage[i][k]);
		}
	}
	outFs.close();
	out.println("<h1><a href='http://localhost:8080/JSP_Study1/download.jsp?file="
			+OutFname+"'><button>이미지 다운로드</button></a>");
%>
<form form method="post" action="Photo_Client.jsp">
	<p> <input type='submit' value='영상 처리 화면으로'></p>
</form>
</body>
</html>