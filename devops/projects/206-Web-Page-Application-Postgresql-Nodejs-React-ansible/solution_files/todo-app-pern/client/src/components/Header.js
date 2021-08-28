import React from "react";
import cw from "../assets/cw.svg";
import "./style.css";

const Header = () => {
  return (
    <div>
      <div class="text-center">
        <img src={cw} alt="clarusway" className="cw" />
        <h6 className="text-center mt-5">
          This app developed by Clarusway Developers.
        </h6>
        <h1 className="text-center mt-5 header-text">Clarus Todos</h1>
      </div>
    </div>
  );
};

export default Header;
