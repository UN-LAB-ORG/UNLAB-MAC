clc(); close("all"); clear();

% Parameters
beamwidth = [0.1, 3, 12];
r = 18;
lambda = 0.05;

beamwidth = deg2rad(beamwidth);
lengthsub = r ./ tan(pi / 2 - beamwidth / 2);
area_t    = 0.5 * 2 * lengthsub * r;

pdf_a = [];
for x = 0 : 6
    temp = (lambda * area_t) .^ x .* exp(-lambda .* area_t) ./ factorial(x);
    pdf_a = [pdf_a; temp];
end
x = 0 : x;

figure();
plot(x, pdf_a(:,1)); hold("on");
plot(x, pdf_a(:,2));
plot(x, pdf_a(:,3)); grid("on");
xlabel("Number of Nodes");
ylabel("PDF")
legend("0.1\circ","3\circ","12\circ");
